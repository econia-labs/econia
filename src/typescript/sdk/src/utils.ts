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
    case "Cancel":
      return 0;
    case "Change":
      return 1;
    case "Evict":
      return 2;
    case "Place":
      return 3;
    default:
      throw new Error(`Unknown maker event type: ${makerEventType}`);
  }
};

export const sideToNumber = (side: Side): number => {
  switch (side) {
    case "Bid":
      return 0;
    case "Ask":
      return 1;
    default:
      throw new Error(`Unknown side: ${side}`);
  }
};

export const sideToBoolean = (side: Side): boolean => {
  switch (side) {
    case "Bid":
      return false;
    case "Ask":
      return true;
    default:
      throw new Error(`Unknown side: ${side}`);
  }
};

export const advanceStyleToNumber = (advanceStyle: AdvanceStyle): number => {
  switch (advanceStyle) {
    case "Ticks":
      return 0;
    case "Percent":
      return 1;
    default:
      throw new Error(`Unknown advance style: ${advanceStyle}`);
  }
};

export const selfMatchBehaviorToNumber = (
  selfMatchBehavior: SelfMatchBehavior
): number => {
  switch (selfMatchBehavior) {
    case "Abort":
      return 0;
    case "CancelBoth":
      return 1;
    case "CancelMaker":
      return 2;
    case "CancelTaker":
      return 3;
    default:
      throw new Error(`Unknown self match behavior: ${selfMatchBehavior}`);
  }
};

export const restrictionToNumber = (restriction: Restriction): number => {
  switch (restriction) {
    case "NoRestriction":
      return 0;
    case "FillOrAbort":
      return 1;
    case "ImmediateOrCancel":
      return 2;
    default:
      throw new Error(`Unknown restriction: ${restriction}`);
  }
};

export const orderStateToNumber = (orderState: OrderState): number => {
  switch (orderState) {
    case "Open":
      return 0;
    case "Filled":
      return 1;
    case "Cancelled":
      return 2;
    case "Evicted":
      return 3;
    default:
      throw new Error(`Unknown order state: ${orderState}`);
  }
};
