import { mockConnection } from './testUtilts';
import { NetworkResponseMiddleware } from '../NetworkResponse';

it('is disabled when device capability includes `nativeNetworkInspection`', () => {
  const connection = mockConnection({ page: { capabilities: { nativeNetworkInspection: true } } });
  const handler = new NetworkResponseMiddleware(connection);
  expect(handler.isEnabled()).toBe(false);
});

it('is enabled when device capability is missing `nativeNetworkInspection`', () => {
  const connection = mockConnection();
  const handler = new NetworkResponseMiddleware(connection);
  expect(handler.isEnabled()).toBe(true);
});

it('responds to response body from device and debugger', () => {
  const connection = mockConnection();
  const handler = new NetworkResponseMiddleware(connection);

  // Expect the device message to be handled
  expect(
    handler.handleDeviceMessage({
      method: 'Expo(Network.receivedResponseBody)',
      params: {
        requestId: '1337',
        body: 'hello',
        base64Encoded: false,
      },
    })
  ).toBe(true);

  // Expect the debugger message to be handled
  expect(
    handler.handleDebuggerMessage({
      id: 420,
      method: 'Network.getResponseBody',
      params: { requestId: '1337' },
    })
  ).toBe(true);

  // Expect the proper response was sent
  expect(connection.debuggerInfo.socket.send).toBeCalledWith(
    JSON.stringify({
      id: 420,
      result: {
        body: 'hello',
        base64Encoded: false,
      },
    })
  );
});

it('does not respond to non-existing response', () => {
  const connection = mockConnection();
  const handler = new NetworkResponseMiddleware(connection);

  // Expect the debugger message to not be handled
  expect(
    handler.handleDebuggerMessage({
      id: 420,
      method: 'Network.getResponseBody',
      params: { requestId: '1337' },
    })
  ).toBe(false);

  expect(connection.debuggerInfo.socket.send).not.toBeCalled();
});
