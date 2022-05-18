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
      subscribe(callback: (value: T) => any): void;
    }

    // interface Send<T> {
    //   send(value: T): void;
    // }

    function init(args: Args): App;
  }
}
