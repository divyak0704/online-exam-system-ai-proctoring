-- ============================================================
-- AI Proctored Exam System – Database Migration Script
-- Run this once against your MySQL online_exam database
-- ============================================================

-- 1. Extend proctoring_logs with AI proctoring columns
ALTER TABLE proctoring_logs
  ADD COLUMN IF NOT EXISTS head_pose        VARCHAR(50)  DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS eye_gaze         VARCHAR(50)  DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS object_detected  VARCHAR(100) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS screenshot_path  VARCHAR(255) DEFAULT NULL;

-- 2. Screenshot store table
CREATE TABLE IF NOT EXISTS exam_screenshots (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  user_id         INT          NOT NULL,
  exam_id         INT          NOT NULL,
  screenshot_path VARCHAR(500) NOT NULL,
  captured_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_exam (user_id, exam_id)
);
