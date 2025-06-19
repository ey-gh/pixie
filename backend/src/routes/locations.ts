// ./src/routes/locations.ts
import { Router } from 'express';
import { getLocationsHandler, createLocationHandler } from '../controllers/locationsController';

const router = Router();

router.get('/', getLocationsHandler);
router.post('/', createLocationHandler);

export default router;
