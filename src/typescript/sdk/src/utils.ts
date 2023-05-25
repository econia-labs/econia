import { type MakerEventType } from "./events";
import {
  type AdvanceStyle,
  type OrderState,
  type Restriction,
  type SelfMatchBehavior,
  type Side,
} from "./order";

export const makerEventTypeToNumber = (
  makerEventType: MakerEventType
): number => {
  switch (makerEventType) {
    case "cancel":
      return 0;
    case "change":
      return 1;
    case "evict":
      return 2;
    case "place":
      return 3;
    default:
      throw new Error(`Unknown maker event type: ${makerEventType}`);
  }
};

export const sideToNumber = (side: Side): number => {
  switch (side) {
    case "bid":
      return 0;
    case "ask":
      return 1;
    default:
      throw new Error(`Unknown side: ${side}`);
  }
};

export const sideToBoolean = (side: Side): boolean => {
  switch (side) {
    case "bid":
      return false;
    case "ask":
      return true;
    default:
      throw new Error(`Unknown side: ${side}`);
  }
};

export const advanceStyleToNumber = (advanceStyle: AdvanceStyle): number => {
  switch (advanceStyle) {
    case "ticks":
      return 0;
    case "percent":
      return 1;
    default:
      throw new Error(`Unknown advance style: ${advanceStyle}`);
  }
};

export const selfMatchBehaviorToNumber = (
  selfMatchBehavior: SelfMatchBehavior
): number => {
  switch (selfMatchBehavior) {
    case "abort":
      return 0;
    case "cancelBoth":
      return 1;
    case "cancelMaker":
      return 2;
    case "cancelTaker":
      return 3;
    default:
      throw new Error(`Unknown self match behavior: ${selfMatchBehavior}`);
  }
};

export const restrictionToNumber = (restriction: Restriction): number => {
  switch (restriction) {
    case "noRestriction":
      return 0;
    case "fillOrAbort":
      return 1;
    case "immediateOrCancel":
      return 2;
    default:
      throw new Error(`Unknown restriction: ${restriction}`);
  }
};

export const orderStateToNumber = (orderState: OrderState): number => {
  switch (orderState) {
    case "open":
      return 0;
    case "filled":
      return 1;
    case "cancelled":
      return 2;
    case "evicted":
      return 3;
    default:
      throw new Error(`Unknown order state: ${orderState}`);
  }
};
