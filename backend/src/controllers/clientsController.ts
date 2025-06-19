// src/controllers/clientsController.ts
import { Request, Response } from 'express';
import { getAllClients } from '../db/clients';

export async function getClientsHandler(req: Request, res: Response) {
  try {
    const clients = await getAllClients();
    res.status(200).json({ data: clients });
  } catch (err) {
    console.error('Failed to fetch clients:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
}
