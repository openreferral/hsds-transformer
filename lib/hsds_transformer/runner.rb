module HsdsTransformer
  class Runner

    VALID_CUSTOM_TRANSFORMERS = %w(Open211MiamiTransformer IlaoTransformer)

    # Args:
    # input_path - indicates the dir containing the input data files
    # output_path - indicates the dir you want the resulting HSDS files to go
    # include_custom - Default: false - indicates that the final output CSVs should include the non-HSDS columns that the original input CSVs had
    # zip_output - Default: false - indicates whether you want the output to be zipped into a single datapackage.zip
    # custom_transformer - Default: nil - indicates the custom transformer class you want to use. This arg does not get passed to transformer classes
    def self.run(args)
      custom = args.delete(:custom_transformer)
      validate_custom(custom)

      transformer = custom ? custom_transformer(custom) : BaseTransformer

      transformer.run(args)
    end

    def self.validate_custom(custom)
      if custom && !VALID_CUSTOM_TRANSFORMERS.include?(custom)
        raise InvalidCustomTransformerException
      end
    end

    def self.custom_transformer(custom)
      klass = "HsdsTransformer::" + custom
      Object.const_get(klass)
    end
  end
end