# frozen_string_literal: true
require 'json'

module Export

  def export_data (data, filename, export_dir, timestamp)

    # create directories
    export_dir_path = Pathname.new(export_dir)
    timestamp_subdir_path = export_dir_path.join(timestamp)

    export_dir_path.mkdir unless export_dir_path.exist?
    timestamp_subdir_path.mkdir unless timestamp_subdir_path.exist?

    # JSON export
    File.open(timestamp_subdir_path.join(filename + ".json"), 'wb') do |file|
      file.write(data.to_json)
    end

    # Binary export
    File.open(timestamp_subdir_path.join(filename), 'wb') do |file|
      file.write(Marshal.dump(data))
    end
  end
end
