// ./src/db/attendance.ts
import { db } from '../config/db';

export async function getAllAttendanceLogs() {
  const result = await db.query(`
    SELECT * FROM attendance_log
    ORDER BY service_date DESC
    LIMIT 100
  `);
  return result.rows;
}

export async function insertAttendanceLog(data: {
  client_id: string;
  service_date: string;
  status: string;
  location_id?: string;
}) {
  const { client_id, service_date, status, location_id } = data;

  const result = await db.query(
    `INSERT INTO attendance_log (client_id, service_date, status, location_id)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [client_id, service_date, status, location_id ?? null]
  );
  return result.rows[0];
}
