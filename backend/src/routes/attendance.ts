// ./src/routes/attendance.ts
import { Router } from 'express';
import { getAttendanceHandler, createAttendanceHandler } from '../controllers/attendanceController';

const router = Router();

router.get('/', getAttendanceHandler);
router.post('/', createAttendanceHandler);

export default router;
