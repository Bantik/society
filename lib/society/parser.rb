module Society

  class Parser

    attr_accessor
    def self.for_files(file_path, formatter)
      new(::Analyst.for_files(file_path), formatter)
    end

    def self.for_source(source, formatter)
      new(::Analyst.for_source(source), formatter)
    end

    attr_reader :analyzer, :reporter

    def initialize(analyzer, formatter)
      @analyzer = analyzer
      @reporter = formatter.new(
        heatmap_json: heatmap_json,
        network_json: network_json,
        data_directory: "./doc/society/" # FIXME don't hardcode
      )
    end

    def report
      reporter.write
    end

    private

    def classes
      @classes ||= analyzer.classes
    end

    def class_graph
      @class_graph ||= begin
        associations = associations_from(classes) + references_from(classes)
        ObjectGraph.new(nodes: classes, edges: associations)
      end
    end

    def heatmap_json
      Society::Formatter::Graph::Heatmap.new(class_graph).to_json
    end

    # TODO pass in class name, don't assume #first
    def method_graph
      # @method_graph ||= begin
      #   graph = ObjectGraph.new
      #   target = analyzer.classes.first
      #   graph.nodes = target.all_methods.map do |method|
      #     Node.new(
      #       name: method.name,
      #       edges: [] #method.references
      #     )
      #   end
      #   graph
      # end
    end

    def network_json
      Society::Formatter::Graph::Network.new(class_graph).to_json
    end

    # TODO: this is dumb, cuz it depends on class_graph to be called first,
    #       but i'm just doing it for debugging right now, so LAY OFF ME
    def unresolved_edges
      {
        associations: @association_processor.unresolved_associations,
        references: @reference_processor.unresolved_references
      }
    end

    def debug
      {
        classes: analyzer.classes,
        resolved: {
          associations: @association_processor.associations,
          references: @reference_processor.references
        },
        unresolved: unresolved_edges,
        stats: {
          resolved_associations: @association_processor.associations.size,
          unresolved_associations: @association_processor.unresolved_associations.size,
          resolved_references: @reference_processor.references.size,
          unresolved_references: @reference_processor.unresolved_references.size
        }
      }
    end

    def class_names
      @class_names ||= analyzer.classes.map(&:full_name)
    end

    def associations_from(all_classes)
      @association_processor ||= AssociationProcessor.new(all_classes)
      @association_processor.associations
    end

    def references_from(all_classes)
      @reference_processor ||= ReferenceProcessor.new(all_classes)
      @reference_processor.references
    end

  end

end

