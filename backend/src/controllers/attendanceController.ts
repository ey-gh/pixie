// ./src/controllers/attendanceController.ts
import { Request, Response } from 'express';
import { getAllAttendanceLogs, insertAttendanceLog } from '../db/attendance';
import { sendSuccess, sendError } from '../utils/responses';

export async function getAttendanceHandler(req: Request, res: Response) {
  try {
    const logs = await getAllAttendanceLogs();
    return sendSuccess(res, logs);
  } catch (err) {
    console.error('GET /attendance failed:', err);
    return sendError(res, 'Failed to fetch attendance log');
  }
}

export async function createAttendanceHandler(req: Request, res: Response) {
  const { client_id, service_date, status, location_id } = req.body;

  if (!client_id || !service_date || !status) {
    return sendError(res, 'Missing required fields: client_id, service_date, status', 400);
  }

  try {
    const record = await insertAttendanceLog({
      client_id,
      service_date,
      status,
      location_id,
    });

    return sendSuccess(res, record, 201);
  } catch (err) {
    console.error('POST /attendance failed:', err);
    return sendError(res, 'Failed to log attendance');
  }
}
