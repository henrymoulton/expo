import { PureComponent, createRef, useRef, useEffect } from 'react';
import NativeVideoModule from './NativeVideoModule';
import NativeVideoView from './NativeVideoView';
export function useVideoPlayer(source) {
    const playerRef = useRef(null);
    const currentSource = useRef(source);
    const parsedSource = typeof source === 'string' ? { uri: source } : source;
    useEffect(() => {
        return () => {
            playerRef.current?.release();
            playerRef.current = null;
        };
    }, []);
    if (playerRef.current === null) {
        playerRef.current = new NativeVideoModule.VideoPlayer(parsedSource);
    }
    else if (currentSource.current !== source) {
        playerRef.current.release();
        playerRef.current = new NativeVideoModule.VideoPlayer(parsedSource);
        currentSource.current = source;
    }
    return playerRef.current;
}
/**
 * Returns whether the current device supports Picture in Picture (PiP) mode.
 * @returns A `boolean` which is `true` if the device supports PiP mode, and `false` otherwise.
 * @platform android
 * @platform ios
 */
export function isPictureInPictureSupported() {
    return NativeVideoModule.isPictureInPictureSupported();
}
export class VideoView extends PureComponent {
    nativeRef = createRef();
    replace(source) {
        if (typeof source === 'string') {
            this.nativeRef.current?.replace({ uri: source });
            return;
        }
        this.nativeRef.current?.replace(source);
    }
    enterFullscreen() {
        this.nativeRef.current?.enterFullscreen();
    }
    exitFullscreen() {
        this.nativeRef.current?.exitFullscreen();
    }
    /**
     * Enters Picture in Picture (PiP) mode. Throws an exception if the device does not support PiP.
     * > **Note:** Only one player can be in Picture in Picture (PiP) mode at a time.
     * @platform android
     * @platform ios 14+
     */
    startPictureInPicture() {
        return this.nativeRef.current?.startPictureInPicture();
    }
    /**
     * Exits Picture in Picture (PiP) mode.
     * @platform android
     * @platform ios 14+
     */
    stopPictureInPicture() {
        return this.nativeRef.current?.stopPictureInPicture();
    }
    render() {
        const { player, ...props } = this.props;
        const playerId = getPlayerId(player);
        return <NativeVideoView {...props} player={playerId} ref={this.nativeRef}/>;
    }
}
// Temporary solution to pass the shared object ID instead of the player object.
// We can't really pass it as an object in the old architecture.
// Technically we can in the new architecture, but it's not possible yet.
function getPlayerId(player) {
    if (player instanceof NativeVideoModule.VideoPlayer) {
        // @ts-expect-error
        return player.__expo_shared_object_id__;
    }
    if (typeof player === 'number') {
        return player;
    }
    return null;
}
//# sourceMappingURL=VideoView.js.map