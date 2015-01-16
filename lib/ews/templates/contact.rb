module Viewpoint::EWS
  module Template
    # Template for creating Contacts.
    # @see http://msdn.microsoft.com/en-us/library/exchange/aa564765.aspx
    class Contact < OpenStruct

      # Available parameters with the required ordering
      PARAMETERS = %w{mime_content item_id parent_folder_id item_class subject sensitivity body attachments date_time_received size categories importance in_reply_to is_submitted is_draft is_from_me is_resend is_unmodified internet_message_headers date_time_sent date_time_created response_objects reminder_due_by reminder_is_set reminder_minutes_before_start display_cc display_to has_attachments extended_property culture effective_rights last_modified_name last_modified_time is_associated web_client_read_form_query_string web_client_edit_form_query_string conversation_id unique_body file_as file_as_mapping display_name given_name initials middle_name nickname complete_name company_name email_addresses physical_addresses phone_numbers assistant_name birthday business_home_page children companies contact_source department generation im_addresses job_title manager mileage office_location postal_address_index profession spouse_name surname wedding_anniversary has_picture phonetic_full_name phonetic_first_name phonetic_last_name alias notes photo user_smime_certificate ms_exchange_certificate directory_id manager_mailbox direct_reports}.map(&:to_sym).freeze

      # Returns a new Contact template
      def initialize(opts = {})
        super opts.dup
      end

      # EWS CreateItem container
      # @return [Hash]
      def to_ews_create(opts = {})
        structure = {}

        if self.saved_item_folder_id
          if self.saved_item_folder_id.kind_of?(Hash)
            structure[:saved_item_folder_id] = saved_item_folder_id
          else
            structure[:saved_item_folder_id] = {id: saved_item_folder_id}
          end
        end

        structure[:items] = [{contact: to_ews_item}]
        structure
      end

      # EWS Item hash
      #
      # Puts all known parameters in the required ordering and structure
      # @return [Hash]
      def to_ews_item
        item_parameters = {}
        item_parameters[:complete_name] = []
        PARAMETERS.each do |key|
          if !(value = self.send(key)).nil?

            # Convert non duplicable values to String
            case value
              when NilClass, FalseClass, TrueClass, Symbol, Numeric
                value = value.to_s
              end

            # Convert attributes
            case key
              when :given_name, :surname
                # First and last name are stored twice. It is assumed "Full name" can be composed.
                item_parameters[key] = { text: value }
                item_parameters[:complete_name][:first_name] = { text: value } if key == :given_name
                item_parameters[:complete_name][:last_name] = { text: value } if key == :surname
              when :email_addresses
                value.each do |email_key, email_address|
                  item_parameters[key] << { key: email_key, text: email_address }
                end
              when :phone_numbers
                value.each do |phone_key, phone_number|
                  item_parameters[key] << { key: phone_key, text: phone_number }
                end
              else
                item_parameters[key] = value
            end
          end
        end

        item_parameters
      end

    end
  end
end
