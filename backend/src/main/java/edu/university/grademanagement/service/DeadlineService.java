package edu.university.grademanagement.service;

import edu.university.grademanagement.model.entity.GradeSubmissionDeadline;
import edu.university.grademanagement.repository.GradeSubmissionDeadlineRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

/**
 * Deadline Service
 * Business logic for grade submission deadlines
 */
@Service
public class DeadlineService {

    @Autowired
    private GradeSubmissionDeadlineRepository deadlineRepository;

    /**
     * Get all deadlines
     */
    public List<GradeSubmissionDeadline> getAllDeadlines() {
        return deadlineRepository.findAll();
    }

    /**
     * Get deadline by ID
     */
    public GradeSubmissionDeadline getDeadlineById(Long deadlineId) {
        return deadlineRepository.findById(deadlineId)
                .orElseThrow(() -> new RuntimeException("Deadline not found: " + deadlineId));
    }

    /**
     * Get deadline for a specific semester and year
     */
    public Optional<GradeSubmissionDeadline> getDeadline(String semester, Integer academicYear) {
        return deadlineRepository.findBySemesterAndAcademicYear(semester, academicYear);
    }

    /**
     * Get current active deadline
     */
    public Optional<GradeSubmissionDeadline> getCurrentDeadline() {
        List<GradeSubmissionDeadline> activeDeadlines = deadlineRepository.findActiveDeadlines();
        return activeDeadlines.isEmpty() ? Optional.empty() : Optional.of(activeDeadlines.get(0));
    }

    /**
     * Get all active deadlines
     */
    public List<GradeSubmissionDeadline> getActiveDeadlines() {
        return deadlineRepository.findByIsActive("Y");
    }

    /**
     * Get upcoming deadlines
     */
    public List<GradeSubmissionDeadline> getUpcomingDeadlines() {
        return deadlineRepository.findUpcomingDeadlines(LocalDate.now());
    }

    /**
     * Get past deadlines
     */
    public List<GradeSubmissionDeadline> getPastDeadlines() {
        return deadlineRepository.findPastDeadlines(LocalDate.now());
    }

    /**
     * Check if deadline has passed for a specific semester and year
     */
    public boolean isAfterDeadline(String semester, Integer academicYear) {
        Optional<GradeSubmissionDeadline> deadline = getDeadline(semester, academicYear);
        if (deadline.isEmpty()) {
            // No deadline found, assume grades can be submitted
            return false;
        }
        return deadline.get().isPastDeadline();
    }

    /**
     * Check if grades can be submitted for a specific semester and year
     */
    public boolean canSubmitGrades(String semester, Integer academicYear) {
        return !isAfterDeadline(semester, academicYear);
    }

    /**
     * Get deadlines by academic year
     */
    public List<GradeSubmissionDeadline> getDeadlinesByYear(Integer academicYear) {
        return deadlineRepository.findByAcademicYear(academicYear);
    }

    /**
     * Create new deadline
     */
    public GradeSubmissionDeadline createDeadline(GradeSubmissionDeadline deadline) {
        // Check if deadline already exists for this semester/year
        Optional<GradeSubmissionDeadline> existing = getDeadline(deadline.getSemester(), deadline.getAcademicYear());
        if (existing.isPresent()) {
            throw new RuntimeException("Deadline already exists for semester " + deadline.getSemester() + " year " + deadline.getAcademicYear());
        }
        return deadlineRepository.save(deadline);
    }

    /**
     * Update deadline
     */
    public GradeSubmissionDeadline updateDeadline(Long deadlineId, GradeSubmissionDeadline updatedDeadline) {
        GradeSubmissionDeadline deadline = getDeadlineById(deadlineId);
        
        if (updatedDeadline.getSubmissionDeadline() != null) {
            deadline.setSubmissionDeadline(updatedDeadline.getSubmissionDeadline());
        }
        if (updatedDeadline.getIsActive() != null) {
            deadline.setIsActive(updatedDeadline.getIsActive());
        }
        
        return deadlineRepository.save(deadline);
    }

    /**
     * Deactivate deadline
     */
    public GradeSubmissionDeadline deactivateDeadline(Long deadlineId) {
        GradeSubmissionDeadline deadline = getDeadlineById(deadlineId);
        deadline.setIsActive("N");
        return deadlineRepository.save(deadline);
    }

    /**
     * Delete deadline
     */
    public void deleteDeadline(Long deadlineId) {
        GradeSubmissionDeadline deadline = getDeadlineById(deadlineId);
        deadlineRepository.delete(deadline);
    }
}

