module OpenReferralTransformer
  class Runner

    VALID_CUSTOM_TRANSFORMERS = %w(Open211MiamiTransformer IlaoTransformer)

    # Args:
    # input_dir
    # output_dir
    # include_custom - Default: false
    # zip_output - Default: false
    # custom_transformer - Default: nil. Does not get passed to transformer classes
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
      klass = "OpenReferralTransformer::" + custom
      Object.const_get(klass)
    end
  end
end