pub mod bar;
pub mod coin;
pub mod events;
pub mod fill;
pub mod market;
pub mod order;

pub trait IntoInsertable {
    type Insertable;

    fn into_insertable(self) -> Self::Insertable;
}
