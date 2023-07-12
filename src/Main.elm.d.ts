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

    interface DragStartData {
      effectAllowed: 'none' | 'copy' | 'copyLink' | 'copyMove' | 'link' | 'linkMove' | 'move' | 'all' | 'uninitialized';
      event: DragEvent;
    }

    interface DragOverData {
      dropEffect: 'none' | 'copy' | 'link' | 'move';
      event: DragEvent;
    }

    interface Ports {
      setStorage: Subscribe<object>;
      playSound: Subscribe<string>;
      notify: Subscribe<string>;
      dragstart: Subscribe<DragStartData>;
      dragover: Subscribe<DragOverData>;
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
