import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { playManager } from '../utils/AvPlayerManager';
import { sessionManager } from '../utils/AvSessionManager';
import { musicRepository } from '../utils/MusicRepository';
import { defaultMusicSeeds } from '../utils/MusicSeedData';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(_want: Want, _launchParam: AbilityConstant.LaunchParam) {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy() {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    
    // 准备播放器
    playManager.init().then(() => {
      sessionManager.init(this.context);
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
    sessionManager.destroy();
    playManager.release();
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}