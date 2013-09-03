class Pry
  class Command::ShowTree < Pry::ClassCommand
    match 'show-tree'
    group 'Introspection'
    description 'Show tree'

    banner <<-'BANNER'
      Usage: show-tree
    BANNER

    def process
      out = ''
      out += target.eval('self').to_s + "\n"
      Pry::WrappedModule(target.eval('self')).constants.each do |const|
        out += "#{ ' ' * 2 }#{ const.to_s }\n"
      end
      stagger_output out
    end

  end

  Pry::Commands.add_command(Pry::Command::ShowTree)
end
