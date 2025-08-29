import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import Fastify, { FastifyInstance } from 'fastify';

describe('Backend Server', () => {
  let server: FastifyInstance;

  beforeAll(async () => {
    server = Fastify({
      logger: false,
    });

    // Health check endpoint
    server.get('/health', async () => {
      return {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || 'development',
      };
    });

    // Root endpoint
    server.get('/', async () => {
      return {
        name: 'AFL Data Capture API',
        version: '0.1.0',
        status: 'running',
      };
    });

    await server.ready();
  });

  afterAll(async () => {
    await server.close();
  });

  describe('Health Check Endpoint', () => {
    it('should return healthy status', async () => {
      const response = await server.inject({
        method: 'GET',
        url: '/health',
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.status).toBe('healthy');
      expect(body.timestamp).toBeDefined();
      expect(body.uptime).toBeDefined();
      expect(body.environment).toBe('test');
    });
  });

  describe('Root Endpoint', () => {
    it('should return API information', async () => {
      const response = await server.inject({
        method: 'GET',
        url: '/',
      });

      expect(response.statusCode).toBe(200);
      const body = JSON.parse(response.body);
      expect(body.name).toBe('AFL Data Capture API');
      expect(body.version).toBe('0.1.0');
      expect(body.status).toBe('running');
    });
  });

  describe('404 Handling', () => {
    it('should return 404 for unknown routes', async () => {
      const response = await server.inject({
        method: 'GET',
        url: '/unknown-route',
      });

      expect(response.statusCode).toBe(404);
    });
  });
});