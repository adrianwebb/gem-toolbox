
ENV['NUCLEON_NO_PARALLEL'] = '1'

require 'nucleon'

#-------------------------------------------------------------------------------
# Properties
#
# TODO: Utilize Nucleon more effectively

options = {}

opts = OptionParser.new do |opts|
  opts.banner = "Usage: ./install [-tc]"
  opts.separator ""
  opts.separator "This command installs the Coral toolbox scripts into the directory,"
  opts.separator "/usr/local/lib/coral_toolbox (unless --test option given)."
  opts.separator ""
  opts.separator "The installer also takes care of sym linking the executables to the"
  opts.separator "/usr/local/bin directory (without the .sh extension)."
  opts.separator ""
      
  opts.on("-t", "--test", "Run scripts from their local directory") do |t|
    options[:test] = t
  end
  opts.on("-c", "--clean", "Remove all bin links and do NOT generate new ones") do |c|
    options[:clean] = c
  end  
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  opts.parse!
end

if ARGV.empty?
  # Nothing here right now
  # puts opts
  # exit
end

#---

current = File.expand_path(File.dirname(__FILE__))

install_home = ( options[:test] ? current : "/usr/local/lib/coral_toolbox" )
install_bin  = "/usr/local/bin"

state_file   = "#{install_home}/.state"

#-------------------------------------------------------------------------------
# Initialization

unless options[:test] || options[:clean]
  if current != install_home
    FileUtils.rm_rf(install_home) if File.directory?(install_home)
    
    puts "Installing #{current} to #{install_home}"
    FileUtils.cp_r(current, install_home)
    puts ''
  end
end

#---

puts "Loading state"
state = Nucleon::Util::Disk.read(state_file)
puts ''

#-------------------------------------------------------------------------------
# Remove old scripts

if state
  state = Nucleon::Util::Data.symbol_map(Nucleon::Util::Data.parse_json(state))
  
  if options[:clean]
    state[:bin].each do |file|
      puts "Removing: #{file}"
      File.delete(file);
    end
    puts ''
  end  
else
  state = {}
end

#-------------------------------------------------------------------------------
# Link new scripts

state[:bin] = []

unless options[:clean]
  Dir.glob(File.join(install_home, '*.sh')).each do |file|
    bin_name = file.split('/').last.split('.sh').first
    bin_file = "#{install_bin}/#{bin_name}"
  
    puts "Linking: #{bin_file} -> [ #{file} ]"
  
    FileUtils.ln_sf(file, bin_file)
    File.chmod(0755, file)
  
    state[:bin] << bin_file
  end
  puts ''

  #---

  Dir.glob(File.join(install_home, '*.rb')).each do |file|
    bin_name = file.split('/').last.split('.rb').first
    bin_file = "#{install_bin}/#{bin_name}"
  
    if bin_name != 'install'
      puts "Creating: #{bin_file} -> [ #{file} ]"
    
      launch_script = "#!/bin/bash\nruby #{file} $@"
    
      Nucleon::Util::Disk.write(bin_file, launch_script)
      File.chmod(0755, bin_file)
  
      state[:bin] << bin_file
    end
  end
  puts ''
end

#-------------------------------------------------------------------------------
# Finalization

puts "Saving state"
Nucleon::Util::Disk.write(state_file, Nucleon::Util::Data.to_json(state, true))
