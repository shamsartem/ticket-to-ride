export type SentFromElmMsg = 'RefreshAppClicked'

export type ElmApp = {
  ports: {
    sendMessage: {
      subscribe: (
        callback: (value: { tag: SentFromElmMsg; payload: string }) => void,
      ) => void
    }
    gotMessage: {
      send: (msg: { tag: string; payload: unknown }) => void
    }
  }
}

declare global {
  interface Window {
    Elm: {
      Main: {
        init: (config: {
          node: Element
          flags: {
            windowWidth: number
          }
        }) => ElmApp
      }
    }
  }
}

const appEl = document.getElementById('app')
if (appEl === null) throw new Error('Page does not have #app element')

export const app = window.Elm.Main.init({
  node: appEl,
  flags: {
    windowWidth: window.innerWidth,
  },
})

export function sendToElm(msg: 'NeedRefresh'): void
export function sendToElm(msg: 'OfflineReady'): void
export function sendToElm(tag: string, payload?: unknown): void {
  app.ports.gotMessage.send({ tag, payload })
}
