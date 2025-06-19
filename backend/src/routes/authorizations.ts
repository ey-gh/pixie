// ./src/routes/locations.ts
import { Router } from 'express';
import { getAuthorizationsHandler, createAuthorizationHandler } from '../controllers/authorizationsController';

const router = Router();

router.get('/', getAuthorizationsHandler);
router.post('/', createAuthorizationHandler);

export default router;
