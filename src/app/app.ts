// eslint-disable-next-line import/no-unresolved
import { registerSW } from 'virtual:pwa-register'

import { sendToElm, app, SentFromElmMsg } from './elm'
import './styles/common.scss'

const updateSW = registerSW({
  onNeedRefresh(): void {
    sendToElm('NeedRefresh')
  },
  onOfflineReady(): void {
    sendToElm('OfflineReady')
  },
})

app.ports.sendMessage.subscribe(
  ({ tag }: { tag: SentFromElmMsg; payload: unknown }): void => {
    switch (tag) {
      case 'RefreshAppClicked': {
        // eslint-disable-next-line @typescript-eslint/no-floating-promises
        updateSW()
        break
      }
      default: {
        const _exhaustiveCheck: never = tag
        return _exhaustiveCheck
      }
    }
  },
)
