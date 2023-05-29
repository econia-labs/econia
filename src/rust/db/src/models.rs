pub mod bar;
pub mod coin;
pub mod events;
pub mod fill;
pub mod market;
pub mod order;

pub trait ToInsertable {
    type Insertable<'a>
    where
        Self: 'a;

    fn to_insertable(&self) -> Self::Insertable<'_>;
}
