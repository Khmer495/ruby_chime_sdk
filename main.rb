# frozen_string_literal: true

require 'pp'

require 'ulid'

require './aws_chime_sdk'

aws_chime_sdk = AwsChimeSdk.new
meeting_id = aws_chime_sdk.create_meeting
begin
  attendee_id, join_token = aws_chime_sdk.join_meeting(meeting_id, ULID.generate)
  media_pipeline_id = aws_chime_sdk.start_recording(meeting_id)
  aws_chime_sdk.stop_recording(media_pipeline_id)
rescue StandardError => e
  p e.class
  p e.message
  pp e.backtrace
end
aws_chime_sdk.delete_meeting(meeting_id)
