class Pry
  class Command::ShellCommand < Pry::ClassCommand
    match(/\.(.*)/)
    group 'Input and Output'
    description "All text following a '.' is forwarded to the shell."
    command_options :listing => '.<shell command>', :use_prefix => false,
      :takes_block => true

    banner <<-'BANNER'
      Usage: .COMMAND_NAME

      All text following a "." is forwarded to the shell.

      .ls -aF
      .uname
    BANNER

    def process(cmd)
      if cmd =~ /^cd\s*(.*)/i
        process_cd parse_destination($1)
      else
        pass_block(cmd)
        if command_block
          command_block.call `#{cmd}`
        else
          _pry_.config.system.call(output, cmd, _pry_)
        end
      end
    end

    private

    def parse_destination(dest)
      return "~" if dest.empty?
      return dest unless dest == "-"
      state.old_pwd || raise(CommandError, "No prior directory available")
    end

    def cd_path
      ENV[ 'CDPATH' ]
    end

    def process_cd(dest)
      begin
        state.old_pwd = Dir.pwd
  
        # Don't do thinks for ".", "..", "-" and stuff starting with "/" and "~".
        if dest && (!([ ".", "..", "-" ].include?(dest))) && (dest !~ /^[#{File::PATH_SEPARATOR}~]/)
          cdpath = cd_path()
          if cdpath && (cdpath.length > 0)
            paths = cdpath.split(File::PATH_SEPARATOR)
            paths.each do |next_path|
              next_dest = "#{next_path}#{File::SEPARATOR}#{dest}"
              if File.directory?(next_dest)
                return Dir.chdir(File.expand_path(next_dest))
              end
            end
          end
        end

        Dir.chdir File.expand_path(dest)
      rescue Errno::ENOENT
        raise CommandError, "No such directory: #{dest}"
      end
    end
  end

  Pry::Commands.add_command(Pry::Command::ShellCommand)
end
