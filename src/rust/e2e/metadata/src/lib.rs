pub struct Metadata<T> {
    namespace: String,
    name: String,
    result: T,
}

impl<T> Metadata<T> {
    pub fn new(namespace: impl Into<String>, name: impl Into<String>, result: T) -> Self {
        Self { namespace: namespace.into(), name: name.into(), result }
    }

    pub fn namespace(&self) -> &str {
        &self.name
    }

    pub fn name(&self) -> &str {
        &self.name
    }

    pub fn result(&self) -> &T {
        &self.result
    }

    pub fn decompose(self) -> (String, String, T) {
        (self.namespace, self.name, self.result)
    }
}
