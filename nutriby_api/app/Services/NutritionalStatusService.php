<?php

namespace App\Services;

use App\Models\Child;
use App\Models\GrowthStandard;
use Carbon\Carbon;

/**
 * Service class for calculating a child's nutritional status.
 *
 * This service computes Z-scores for Height-for-Age (HFA), Weight-for-Age (WFA),
 * and Weight-for-Height (WFH) based on WHO growth standards to provide a
 * comprehensive nutritional assessment.
 */
class NutritionalStatusService
{
    /**
     * The main entry point for calculating all nutritional statuses for a child.
     *
     * @param Child $child The child model instance containing current measurement data.
     * @return array An associative array containing the status for HFA, WFA, WFH, and generated notes.
     */
    public function calculate(Child $child): array
    {
        // Calculate the child's age in months, which is a primary key for HFA and WFA.
        $ageInMonths = $this->calculateAgeInMonths($child->birth_date);

        // Fetch the necessary growth standard references from the database.
        $standardHfa = $this->getStandardByAge($ageInMonths, $child->gender, 'hfa');
        $standardWfa = $this->getStandardByAge($ageInMonths, $child->gender, 'wfa');
        $standardWfh = $this->getStandardByHeight($child->current_height, $child->gender);

        // Calculate Z-scores using the fetched standards and the child's measurements.
        $zScoreHfa = $this->calculateZScore($child->current_height, $standardHfa);
        $zScoreWfa = $this->calculateZScore($child->current_weight, $standardWfa);
        $zScoreWfh = $this->calculateZScore($child->current_weight, $standardWfh);

        // Determine the status category based on each Z-score.
        $statusHfa = $this->determineStatus($zScoreHfa, 'hfa');
        $statusWfa = $this->determineStatus($zScoreWfa, 'wfa');
        $statusWfh = $this->determineStatus($zScoreWfh, 'wfh');

        // Generate comprehensive, actionable notes for the parent based on all statuses.
        $notes = $this->generateNotes($statusHfa, $statusWfa, $statusWfh);

        return [
            'status_hfa' => $statusHfa,
            'status_wfa' => $statusWfa,
            'status_wfh' => $statusWfh,
            'z_score_hfa_value' => $zScoreHfa, 
            'z_score_wfa_value' => $zScoreWfa, 
            'z_score_wfh_value' => $zScoreWfh,
            'notes' => $notes,
        ];
    }

    /**
     * Fetches the growth standard based on age.
     *
     * @param int|null $ageInMonths
     * @param string $gender
     * @param string $metric 'hfa' or 'wfa'
     * @return GrowthStandard|null
     */
    private function getStandardByAge(?int $ageInMonths, string $gender, string $metric): ?GrowthStandard
    {
        if (is_null($ageInMonths)) {
            return null;
        }

        return GrowthStandard::where('age_in_months', $ageInMonths)
            ->where('gender', $gender)
            ->where('metric', $metric)
            ->first();
    }

    /**
     * Fetches the WFH growth standard based on the closest height.
     *
     * @param float $height
     * @param string $gender
     * @return GrowthStandard|null
     */
    private function getStandardByHeight(float $height, string $gender): ?GrowthStandard
    {
        // Finds the standard record where the 'reference_height_cm' is closest to the child's current height.
        return GrowthStandard::where('metric', 'wfh')
            ->where('gender', $gender)
            ->orderByRaw('ABS(reference_height_cm - ?)', [$height])
            ->first();
    }

    /**
     * Calculates the Z-score for a given measurement against a standard.
     *
     * @param float $measurement The child's weight or height.
     * @param GrowthStandard|null $standard The WHO standard data.
     * @return float|null The calculated Z-score, or null if calculation is not possible.
     */
    private function calculateZScore(float $measurement, ?GrowthStandard $standard): ?float
    {
        if (!$standard) {
            return null;
        }

        // This simplified Z-score calculation determines the distance from the median
        // in terms of standard deviations. It provides a good approximation for categorization.
        $median = $standard->median;
        $sd_pos = $standard->sd1_pos - $median;
        $sd_neg = $median - $standard->sd1_neg;

        if ($measurement >= $median) {
            $sd = ($sd_pos > 0) ? $sd_pos : 1;
        } else {
            $sd = ($sd_neg > 0) ? $sd_neg : 1;
        }

        return ($measurement - $median) / $sd;
    }

    /**
     * Determines the nutritional status category based on a Z-score.
     * The categories are based on WHO Child Growth Standards definitions.
     *
     * @param float|null $zScore
     * @param string $metric 'hfa', 'wfa', or 'wfh'
     * @return string The human-readable status category.
     */
    private function determineStatus(?float $zScore, string $metric): string
    {
        if (is_null($zScore)) {
            return 'Data Tidak Cukup';
        }

        if ($zScore < -3) {
            return match ($metric) {
                'hfa' => 'Sangat Pendek (Stunting Berat)',
                'wfa' => 'Berat Badan Sangat Kurang',
                'wfh' => 'Gizi Buruk (Sangat Kurus)',
            };
        } elseif ($zScore < -2) {
            return match ($metric) {
                'hfa' => 'Pendek (Stunting)',
                'wfa' => 'Berat Badan Kurang',
                'wfh' => 'Gizi Kurang (Kurus)',
            };
        } elseif ($zScore <= 1) { // WHO Normal Range is generally up to +1 for some metrics before 'at risk'
            return 'Normal';
        } elseif ($zScore <= 2) {
            return match ($metric) {
                'wfh' => 'Berisiko Gizi Lebih',
                default => 'Normal',
            };
        } else { // $zScore > 2
            return match ($metric) {
                'hfa' => 'Tinggi',
                'wfa' => 'Berat Badan Lebih',
                'wfh' => 'Gizi Lebih / Obesitas',
            };
        }
    }

    /**
     * Generates actionable advice for parents based on the combination of nutritional statuses.
     *
     * @param string $statusHfa
     * @param string $statusWfa
     * @param string $statusWfh
     * @return string A consolidated note for the parent.
     */
    private function generateNotes(string $statusHfa, string $statusWfa, string $statusWfh): string
    {
        // Prioritize the most severe condition for the primary message.
        if (str_contains($statusWfh, 'Gizi Buruk')) {
            return 'PERHATIAN: Anak Anda terindikasi Gizi Buruk (sangat kurus). Kondisi ini memerlukan penanganan medis segera. Mohon segera konsultasikan dengan dokter anak atau puskesmas terdekat.';
        }
        if (str_contains($statusHfa, 'Stunting')) {
            return 'Anak Anda terindikasi stunting (pendek). Sangat penting untuk fokus pada asupan kaya protein hewani (hati ayam, telur, ikan) dan seng untuk mendukung pertumbuhan tinggi badan. Konsultasikan dengan tenaga kesehatan untuk panduan lebih lanjut.';
        }
        if (str_contains($statusWfh, 'Gizi Kurang')) {
            return 'Anak Anda terindikasi kurus (gizi kurang). Pastikan setiap porsi MPASI mengandung cukup kalori dan lemak sehat (santan, minyak, alpukat) untuk membantu menaikkan berat badannya sesuai tinggi badan.';
        }
        if (str_contains($statusWfa, 'Kurang')) {
            return 'Berat badan anak Anda kurang untuk usianya. Tingkatkan frekuensi makan dan pastikan makanan padat gizi untuk membantu mengejar pertumbuhannya.';
        }
        if ($statusHfa === 'Normal' && $statusWfa === 'Normal' && $statusWfh === 'Normal') {
            return 'Selamat! Status gizi anak Anda sangat baik berdasarkan tinggi dan berat badannya. Lanjutkan pola makan bergizi seimbang untuk menjaga tumbuh kembangnya yang optimal.';
        }

        return 'Perhatikan asupan gizi seimbang anak Anda. Untuk hasil yang lebih akurat dan penanganan yang tepat, konsultasikan hasil ini dengan dokter atau ahli gizi.';
    }

    /**
     * Calculates age in months from a birth date string.
     *
     * @param string $birthDate
     * @return int|null
     */
    private function calculateAgeInMonths(string $birthDate): ?int
    {
        try {
            return Carbon::parse($birthDate)->diffInMonths(Carbon::now());
        } catch (\Exception $e) {
            return null;
        }
    }
}