// src/routes/clients.ts
import { Router } from 'express';
import { getClientsHandler, createClientHandler } from '../controllers/clientsController';

const router = Router();

router.get('/', getClientsHandler);
router.post('/', createClientHandler);

export default router;
