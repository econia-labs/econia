use thiserror::Error;

pub mod candlesticks;
pub mod leaderboards;
pub mod markets;
pub mod user_history;

type PipelineAggregationResult = Result<(), PipelineError>;

/// This trait represents a data pipeline.
#[async_trait::async_trait]
pub trait Pipeline {
    /// Returns `true` if the pipeline is ready to be executed (if the process function should be
    /// called now).
    fn ready(&self) -> bool;

    // Used for visibility/logging, returns a static string e.g. "ModelName"
    fn model_name(&self) -> &'static str;

    /// Processes the data and saves the result.
    ///
    /// Before any real work is done, [`Pipeline::ready`] is called. If it returns `false`,
    /// [`PipelineError::NotReady`] is returned.
    async fn process_and_save(&mut self) -> PipelineAggregationResult {
        if self.ready() {
            self.process_and_save_internal().await
        } else {
            Err(PipelineError::NotReady)
        }
    }

    /// Processes the data and saves the result.
    ///
    /// This is an internal function. It should never be called, except in
    /// [`Pipeline::process_and_save`].
    async fn process_and_save_internal(&mut self) -> PipelineAggregationResult;

    /// Process and save historical data that is missing in the database.
    ///
    /// This function should not override already existing data, just process and save any
    /// data that was missing.
    ///
    /// It is recommended that this fuction is run once, before the program starts, to make
    /// sure that the data is up to date.
    async fn process_and_save_historical_data(&mut self) -> PipelineAggregationResult;

    /// The interval at which the [`Pipeline::ready`] function should be polled.
    ///
    /// If `None` is returned, it is up to the caller to decide when to poll.
    fn poll_interval(&self) -> Option<std::time::Duration>;
}

/// Error while trying to process data.
#[derive(Debug, Error)]
pub enum PipelineError {
    /// The data is not ready to be processed.
    ///
    /// If this error arises, it means that [`Pipeline::ready`] returns `false`.
    /// Wait for [`Pipeline::ready`] to return `true` before calling [`Pipeline::process_and_save`] again.
    #[error("Data is not ready to be processed")]
    NotReady,

    /// The data could not be processed.
    ///
    /// An error occured in the processing process.
    /// There are two possible causes to this:
    /// - [`Pipeline::process_internal`] has a bug.
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
