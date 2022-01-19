# frozen_string_literal: true

require 'pp'

require 'aws-sdk-core'
require 'aws-sdk-chime'
require 'ulid'

require './config'

class AwsChimeSdk
  def initialize
    @client = Aws::Chime::Client.new(
      credentials: Aws::Credentials.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
    )
  end

  def create_meeting
    res = @client.create_meeting(
      {
        media_region: 'ap-northeast-1'
      }
    )
    meeting_id = res.meeting.meeting_id

    puts '**********'
    puts "meeting_id: #{meeting_id} is created. response: "
    pp res
    puts '**********'

    meeting_id
  end

  def join_meeting(meeting_id, user_id)
    res = @client.create_attendee(
      {
        meeting_id: meeting_id,
        external_user_id: user_id
      }
    )
    attendee_id = res.attendee.attendee_id
    join_token = res.attendee.join_token

    puts '**********'
    puts "attendee_id: #{attendee_id} is joined to meeting_id: #{meeting_id}. join_token: #{join_token} response: "
    pp res
    puts '**********'

    [attendee_id, res.attendee.join_token]
  end

  def start_recording(meeting_id)
    res = @client.create_media_capture_pipeline(
      {
        source_type: 'ChimeSdkMeeting',
        source_arn: "arn:aws:chime::#{AWS_ACCOUNT_ID}:meeting:#{meeting_id}",
        sink_type: 'S3Bucket',
        sink_arn: AWS_S3_BUCKET_ARN_FOR_CHIME_RECORDING_FILE
      }
    )
    media_pipeline_id = res.media_capture_pipeline.media_pipeline_id

    puts '**********'
    puts "media_pipeline_id: #{media_pipeline_id} starts recording meeting_id: #{meeting_id}. response: "
    pp res
    puts '**********'

    media_pipeline_id
  end

  def stop_recording(media_pipeline_id)
    @client.delete_media_capture_pipeline(
      {
        media_pipeline_id: media_pipeline_id
      }
    )
    puts '**********'
    puts "media_pipeline_id: #{media_pipeline_id} has been stopped"
    puts '**********'
  end

  def delete_meeting(meeting_id)
    @client.delete_meeting(
      {
        meeting_id: meeting_id
      }
    )

    puts '**********'
    puts "meeting_id: #{meeting_id} has been deleted"
    puts '**********'
  end
end
