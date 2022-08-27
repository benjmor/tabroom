import crypto from 'crypto';
import request from 'supertest';
import { assert } from 'chai';
import config from '../../../config/config.js';
import db from '../../models/index.cjs';
import server from '../../../app.js';
import userData from '../../../tests/users.js';

describe('Person Rounds', () => {
	let testAdmin = {};
	let testAdminSession = {};

	beforeAll(async () => {
		testAdmin = await db.person.create(userData.testAdmin);
		testAdminSession = await db.session.create(userData.testAdminSession);
	});

	it('Returns rounds for a person', async () => {
		const hash = crypto.createHash('sha256').update(config.CASELIST_KEY).digest('hex');
		const res = await request(server)
			.get(`/v1/caselist/rounds?person_id=17145&caselist_key=${hash}`)
			.set('Accept', 'application/json')
			.set('Cookie', [`${config.COOKIE_NAME}=${testAdminSession.userkey}`])
			.expect('Content-Type', /json/)
			.expect(200);

		assert.isArray(res.body, 'Response is an array');
	});

	it('Returns rounds for a slug', async () => {
		await db.sequelize.query(`
			INSERT INTO caselist (slug, eventcode, person) VALUES ('/test', 103, 17145)
        `);
		const hash = crypto.createHash('sha256').update(config.CASELIST_KEY).digest('hex');
		const res = await request(server)
			.get(`/v1/caselist/rounds?slug=/test&caselist_key=${hash}`)
			.set('Accept', 'application/json')
			.set('Cookie', [`${config.COOKIE_NAME}=${testAdminSession.userkey}`])
			.expect('Content-Type', /json/)
			.expect(200);

		assert.isArray(res.body, 'Response is an array');
	});

	afterAll(async () => {
		await db.sequelize.query(`
            DELETE FROM caselist WHERE person = 17145
        `);
		await testAdminSession.destroy();
		await testAdmin.destroy();
	});
});
