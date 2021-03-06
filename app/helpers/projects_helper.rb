module ProjectsHelper
  require 'ruby-filemagic'
  require 'mime/types'

  def status_color_panel jobid
    # Return color for buttons based on status
    job = Job.find_by(id: jobid)
    if job.status == "finished"
      'panel-success'  # Finished
    elsif job.status == "running"
      'panel-warning'  # Running
    elsif job.status == "failed"
      'panel-danger'  # Failed
    else
      'panel-default'  # Neutral
    end
  end

  def numResultfiles job
    if job.resultfiles.nil?
      return 0
    end
    return job.resultfiles.size
  end

  def numConfigfiles job
    if job.configfiles.nil?
      return 0
    end
    return job.configfiles.size
  end




end
