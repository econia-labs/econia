use proc_macro::TokenStream;
use syn::{
    parse_macro_input,
    punctuated::{Pair, Punctuated},
    token::Comma,
    ItemFn, Pat,
};

#[proc_macro_attribute]
pub fn e2e_test(attr: TokenStream, item: TokenStream) -> TokenStream {
    let attr = if attr.is_empty() {
        String::from("default")
    } else {
        attr.to_string()
    };

    let mut input = parse_macro_input!(item as ItemFn);

    let args_without_type: Punctuated<Pat, Comma> = input
        .sig
        .inputs
        .iter()
        .map(|e| match e {
            syn::FnArg::Typed(pat) => Pair::new(pat.pat.as_ref().clone(), Some(Comma::default())),
            syn::FnArg::Receiver(_) => panic!("Unexpected receiver"),
        })
        .collect();

    let output = match input.sig.output.clone() {
        syn::ReturnType::Default => quote::quote! { () },
        syn::ReturnType::Type(_, ty) => quote::quote! { #ty },
    };
    input.sig.output = syn::parse_quote! {
        -> Metadata<#output>
    };

    let ItemFn {
        vis,
        sig,
        block,
        ..
    } = input;
    let inputs = sig.inputs.clone();
    let ident = sig.ident.clone();

    quote::quote! {
        #vis
        #sig {
            let result = {
                let core_fn = |#inputs| {
                    async {
                        #block
                    }
                };
                core_fn(#args_without_type)
            };
            Metadata::new(#attr, stringify!(#ident), result.await)
        }
    }.into()
}
