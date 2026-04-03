import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { playManager } from '../utils/AvPlayerManager';
import { sessionManager } from '../utils/AvSessionManager';
import { musicRepository } from '../utils/MusicRepository';
import { defaultMusicSeeds } from '../utils/MusicSeedData';
import { downloadManager } from '../utils/DownloadManager';
import { playbackSnapshotStore } from '../utils/PlaybackSnapshotStore';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private hasShutdownPlayback: boolean = false;

  private shutdownPlaybackRuntime(reason: string): void {
    if (this.hasShutdownPlayback) {
      return;
    }
    this.hasShutdownPlayback = true;
    void (async () => {
      try {
        await sessionManager.stopBackgroundTask();
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', '停止后台任务失败(%{public}s): %{public}s', reason, JSON.stringify(error));
      }

      try {
        await sessionManager.destroy();
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', '销毁音频会话失败(%{public}s): %{public}s', reason, JSON.stringify(error));
      }

      try {
        await playManager.release();
      } catch (error) {
        hilog.error(DOMAIN, 'testTag', '释放播放器失败(%{public}s): %{public}s', reason, JSON.stringify(error));
      }
    })();
  }

  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam) {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy() {
    this.shutdownPlaybackRuntime('onDestroy');
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    
    // 准备播放器
    playManager.init().then(() => {
      sessionManager.init(this.context);
      void playbackSnapshotStore.init(this.context).then(async () => {
        const restored = await playbackSnapshotStore.restoreTo(playManager.currentSong)
        if (restored) {
          hilog.info(DOMAIN, 'testTag', '%{public}s', '播放上下文恢复成功');
        }
      }).catch((error: Error) => {
        hilog.error(DOMAIN, 'testTag', '播放上下文恢复失败: %{public}s', JSON.stringify(error));
      });
      hilog.info(DOMAIN, 'testTag', '%{public}s', '播放器初始化成功');
    }).catch((error: Error) => {
      hilog.error(DOMAIN, 'testTag', '播放器初始化失败: %{public}s', JSON.stringify(error));
    });

    void musicRepository.init(this.context).then(() => {
      return musicRepository.seedIfNeeded(this.context, defaultMusicSeeds)
    }).then(() => {
      hilog.info(DOMAIN, 'testTag', '%{public}s', '音乐数据库初始化成功');
    }).catch((error: Error) => {
      hilog.error(DOMAIN, 'testTag', '音乐数据库初始化失败: %{public}s', JSON.stringify(error));
    });

    void downloadManager.init(this.context).catch((error: Error) => {
      hilog.error(DOMAIN, 'testTag', '下载管理初始化失败: %{public}s', JSON.stringify(error));
    });
    
    //配置加载哪个页面
    windowStage.loadContent('pages/Index', (err: Error) => {
      if (err) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    // 注销会话 和释放播放器
    this.shutdownPlaybackRuntime('onWindowStageDestroy');
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    void playbackSnapshotStore.save(playManager.currentSong)
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}