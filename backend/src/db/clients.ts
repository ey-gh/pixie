// src/db/clients.ts
import { db } from '../config/db';

export async function getAllClients() {
  const result = await db.query(`
    select
      id,
      first_name,
      last_name,
      dob,
      address_city,
      address_state,
      address_zip
    from clients
    order by last_name, first_name
    limit 100
  `);
  return result.rows;
}

type ClientInsertInput = {
  first_name: string;
  last_name: string;
  dob: string;
  address_city?: string;
  address_state?: string;
  address_zip?: string;
};

export async function insertClient(data: ClientInsertInput) {
  const result = await db.query(
    `
    insert into clients (
      first_name,
      last_name,
      dob,
      address_city,
      address_state,
      address_zip
    ) values ($1, $2, $3, $4, $5, $6)
    returning *
    `,
    [
      data.first_name,
      data.last_name,
      data.dob,
      data.address_city,
      data.address_state,
      data.address_zip,
    ]
  );

  return result.rows[0];
}
