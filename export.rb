# frozen_string_literal: true
require 'json'

module Export

  def export_data (data, filename, export_dir)

    # JSON export
    File.open(export_dir.join(filename + ".json"), 'w') do |file|
      file.write(JSON.pretty_generate(data))
    end

    # Binary export
    File.open(export_dir.join(filename), 'wb') do |file|
      file.write(Marshal.dump(data))
    end
  end


  def create_directories(export_dir,timestamp)
    # create directories
    export_dir_path = Pathname.new(export_dir)
    export_dir_with_timestamp_path = export_dir_path.join(timestamp)

    export_dir_path.mkdir unless export_dir_path.exist?
    export_dir_with_timestamp_path.mkdir unless export_dir_with_timestamp_path.exist?

    export_dir_with_timestamp_path
  end
end
