import notify from '../../helpers/pushNotify';
import config from '../../../config/config';
import { debugLogger } from '../../helpers/logger';

export const pushMessage = {

	POST: async (req, res) => {

		debugLogger.info(req.body);

		if (req.body.share_key !== config.SHARE_KEY) {
			debugLogger.info('Invalid internal key, blast not sent');
			return res.status(401).json({ message: 'Invalid internal key' });
		}

		const responseJSON = await notify({
			...req.body,
		});

		debugLogger.info(responseJSON);

		res.status(200).json(responseJSON);
	},
};

export default pushMessage;
