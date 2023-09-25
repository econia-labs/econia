use thiserror::Error;

pub mod candlesticks;
pub mod markets;

type DataAggregationResult = Result<(), DataAggregationError>;

/// This trait represents a data output.
#[async_trait::async_trait]
pub trait Data {
    /// Returns `true` if the data is ready to be processed (if the process function should be
    /// called now).
    fn ready(&self) -> bool;

    /// Processes the data and saves the result.
    ///
    /// Before any real work is done, [`Data::ready`] is called. If it returns `false`,
    /// [`DataProcessingError::NotReady`] is returned.
    async fn process_and_save(&mut self) -> DataAggregationResult {
        if self.ready() {
            self.process_and_save_internal().await
        } else {
            Err(DataAggregationError::NotReady)
        }
    }

    /// Processes the data and saves the result.
    ///
    /// This is an internal function. It should never be called, except in
    /// [`Data::process_and_save`].
    async fn process_and_save_internal(&mut self) -> DataAggregationResult;

    /// Process and save historical data that is missing in the database.
    ///
    /// This function should not override already existing data, just process and save any
    /// data that was missing.
    ///
    /// It is recommended that this fuction is run once, before the program starts, to make
    /// sure that the data is up to date.
    async fn process_and_save_historical_data(&mut self) -> DataAggregationResult;

    /// The interval at which the [`Data::ready`] function should be polled.
    ///
    /// If `None` is returned, it is up to the caller to decide when to poll.
    fn poll_interval(&self) -> Option<std::time::Duration>;
}

/// Error while trying to process data.
#[derive(Debug, Error)]
pub enum DataAggregationError {
    /// The data is not ready to be processed.
    ///
    /// If this error arises, it means that [`Data::ready`] returns `false`.
    /// Wait for [`Data::ready`] to return `true` before calling [`Data::process`] again.
    #[error("Data is not ready to be processed")]
    NotReady,

    /// The data could not be processed.
    ///
    /// An error occured in the processing process.
    /// There are two possible causes to this:
    /// - [`Data::process_internal`] has a bug.
    /// - an external data source is not responding as it should.
    ///
    /// This error should be returned when an error occured, and some action must be taken to fix
    /// it.
    #[error("Data could not be processed, reason: {0}")]
    ProcessingError(anyhow::Error),

    /// The data could not be saved.
    ///
    /// This is likely due to a database error.
    #[error("Data could not be saved, reason: {0}")]
    SavingError(anyhow::Error),

    /// The data is not processable.
    ///
    /// This error should be returned when no further action should be taken, and there is nothing
    /// to save.
    #[error("Data is not processable, reason: {0}")]
    NotProcessable(String),
}
