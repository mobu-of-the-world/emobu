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
      persisted: unknown;
      gitRef: string;
    }

    interface Ports {
      setStorage: Subscribe<Record<string, unknown>>;
      playSound: Subscribe<string>;
      notify: Subscribe<string>;
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
