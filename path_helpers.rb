# encoding: utf-8

def load_project_path(*projects)
  projects.each do |project|
    project = project.to_s
    project_path = File.join(File.dirname(__FILE__), project, 'lib')
    return nil if $LOAD_PATH.include?(File.expand_path(project_path))
    $LOAD_PATH.unshift(File.expand_path(project_path))
  end
end
