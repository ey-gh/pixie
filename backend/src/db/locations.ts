// ./src/db/locations.ts
import { db } from '../config/db';

export async function getAllLocations() {
  const result = await db.query('SELECT * FROM locations ORDER BY name');
  return result.rows;
}

export async function insertLocation(data: {
  name: string;
  address_street?: string;
  address_city?: string;
  address_state?: string;
  address_zip?: string;
}) {
  const { name, address_street, address_city, address_state, address_zip } = data;
  const result = await db.query(
    `INSERT INTO locations (name, address_street, address_city, address_state, address_zip)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [name, address_street, address_city, address_state, address_zip]
  );
  return result.rows[0];
}
