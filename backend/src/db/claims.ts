// ./src/db/claims.ts
import { db } from '../config/db';

export async function getAllClaims() {
  const result = await db.query(`
    SELECT * FROM claims
    ORDER BY submitted_at DESC NULLS LAST, created_at DESC
    LIMIT 100
  `);
  return result.rows;
}

export async function insertClaim(data: {
  client_id: string;
  invoice_id?: string;
  authorization_id?: string;
  service_date: string;
  location_id?: string;
  status?: string;
}) {
  const {
    client_id,
    invoice_id,
    authorization_id,
    service_date,
    location_id,
    status = 'pending'
  } = data;

  const result = await db.query(
    `INSERT INTO claims (
      client_id, invoice_id, authorization_id, service_date, location_id, status
    ) VALUES ($1, $2, $3, $4, $5, $6)
    RETURNING *`,
    [client_id, invoice_id ?? null, authorization_id ?? null, service_date, location_id ?? null, status]
  );

  return result.rows[0];
}
