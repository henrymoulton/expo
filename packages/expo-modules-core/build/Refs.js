import React from 'react';
/**
 * Create a React ref object that is friendly for snapshots.
 * It will be represented as `[React.ref]` in snapshots.
 * @returns a React ref object.
 */
export function createSnapshotFriendlyRef() {
    const ref = React.createRef();
    Object.defineProperty(ref, 'toJSON', {
        value: () => '[React.ref]',
    });
    return ref;
}
//# sourceMappingURL=Refs.js.map