<?php

namespace App\Services;

use App\Models\Child;
use App\Models\GrowthStandard;
use Carbon\Carbon;

class NutritionalStatusService
{
    /**
     * Calculate the nutritional status (HFA and WFA) for a given child.
     *
     * @param Child $child The child object with current weight and height.
     * @return array An array containing status and notes.
     */
    public function calculate(Child $child): array
    {
        // 1. Calculate age in months from birth date.
        $ageInMonths = Carbon::parse($child->birth_date)->diffInMonths(Carbon::now());
        
        // Ensure age is within the supported range (e.g., 6-24 months).
        if ($ageInMonths < 6 || $ageInMonths > 24) {
             return [
                'status_hfa' => 'N/A',
                'status_wfa' => 'N/A',
                'notes' => 'Perhitungan status gizi hanya tersedia untuk anak usia 6-24 bulan.'
            ];
        }

        // 2. Fetch the corresponding WHO growth standard data.
        $standardHfa = $this->getStandard($ageInMonths, $child->gender, 'hfa');
        $standardWfa = $this->getStandard($ageInMonths, $child->gender, 'wfa');
        
        if (!$standardHfa || !$standardWfa) {
            return [
                'status_hfa' => 'Error',
                'status_wfa' => 'Error',
                'notes' => 'Data standar pertumbuhan tidak ditemukan untuk usia dan jenis kelamin ini.'
            ];
        }

        // 3. Calculate Z-scores and determine status.
        $zScoreHfa = $this->calculateZScore($child->current_height, $standardHfa);
        $zScoreWfa = $this->calculateZScore($child->current_weight, $standardWfa);

        $statusHfa = $this->determineStatus($zScoreHfa, 'hfa');
        $statusWfa = $this->determineStatus($zScoreWfa, 'wfa');
        
        // 4. Generate notes based on the results.
        $notes = $this->generateNotes($statusHfa, $statusWfa);

        return [
            'status_hfa' => $statusHfa['status'],
            'status_wfa' => $statusWfa['status'],
            'notes' => $notes
        ];
    }

    /**
     * Fetch a single growth standard record from the database.
     */
    private function getStandard(int $age, string $gender, string $metric): ?GrowthStandard
    {
        return GrowthStandard::where('age_in_months', $age)
                             ->where('gender', $gender)
                             ->where('metric', $metric)
                             ->first();
    }

    /**
     * A simplified Z-score calculation.
     * For a more precise calculation, a more complex formula is needed, but this is a good start.
     * It checks which standard deviation range the measurement falls into.
     */
    private function calculateZScore(float $measurement, GrowthStandard $standard): float
    {
        $median = $standard->median;
        if ($measurement >= $median) {
            $sd = $standard->sd1_pos - $median;
        } else {
            $sd = $median - $standard->sd1_neg;
        }

        // Avoid division by zero if standard deviation is 0.
        if ($sd == 0) return 0;

        return ($measurement - $median) / $sd;
    }

    /**
     * Determine the status category based on Z-score.
     */
    private function determineStatus(float $zScore, string $metric): array
    {
        // Based on WHO Child Growth Standards
        if ($zScore < -3) {
            $status = ($metric === 'hfa') ? 'Sangat Pendek (Stunting Berat)' : 'Berat Badan Sangat Kurang';
        } elseif ($zScore < -2) {
            $status = ($metric === 'hfa') ? 'Pendek- (Stunting)' : 'Berat Badan Kurang';
        } elseif ($zScore <= 2) {
            $status = 'Normal';
        } else {
            $status = ($metric === 'hfa') ? 'Tinggi' : 'Risiko Berat Badan Lebih';
        }
        return ['status' => $status, 'zScore' => $zScore];
    }

    /**
     * Generate actionable advice for the parent.
     */
    private function generateNotes(array $statusHfa, array $statusWfa): string
    {
        if (str_contains($statusHfa['status'], 'Stunting')) {
            return 'Anak Anda terindikasi stunting. Sangat penting untuk fokus pada asupan protein hewani seperti hati ayam, telur, dan ikan untuk mengejar pertumbuhan tinggi badan. Konsultasikan dengan dokter anak untuk penanganan lebih lanjut.';
        }
        if (str_contains($statusWfa['status'], 'Kurang')) {
            return 'Berat badan anak Anda kurang dari standar. Pastikan MPASI mengandung cukup kalori dan lemak sehat seperti santan, minyak, atau alpukat untuk membantu menaikkan berat badan.';
        }
        if ($statusHfa['status'] === 'Normal' && $statusWfa['status'] === 'Normal') {
            return 'Status gizi anak Anda sangat baik! Pertahankan pola makan bergizi seimbang untuk mendukung tumbuh kembangnya yang optimal.';
        }
        return 'Perhatikan asupan gizi seimbang anak Anda. Jika ada kekhawatiran, jangan ragu untuk berkonsultasi dengan tenaga kesehatan.';
    }
}