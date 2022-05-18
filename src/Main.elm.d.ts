export namespace Elm {
  namespace Main {
    interface App {
      ports: Ports;
    }

    interface Args {
      node: HTMLElement;
      flags: Flags;
    }

    interface Flags {
      initialValue: string;
    }

    interface Ports {
      setStorage: Subscribe<object>;
      playSound: Subscribe<string>;
      // sendMessageToElm: Send<string>;
    }

    interface Subscribe<T> {
      subscribe(callback: (value: T) => void): void;
    }

    interface Send<T> {
      send(value: T): void;
    }

    interface KeyEvent {
      sequence: string;
      ctrl: boolean;
      meta: boolean;
      shift: boolean;
    }

    function init(args: Args): App;
  }
}
