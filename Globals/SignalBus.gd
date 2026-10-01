extends Node

@warning_ignore_start("unused_signal")


# Signals for all levels
signal circuit_evaluated # emitted when the logic gate circuit is evaluated (parameter: bool = success)
signal binary_submitted # emitted when the binary value is submitted (parameter: int = decimal value)
signal code_decrypted # emitted when the code is decrypted (parameter: String = decrypted code)
signal tree_traversed # emitted when the tree is traversed (parameter: bool = success)
signal draggable_node_picked
signal draggable_node_dropped

signal enable_draggable_nodes

# Signals for the main level
signal monster_hit
signal monster_defeated
signal round_completed
signal round_started
signal ship_damaged
signal graph_node_travelled
signal graph_node_end_reached


@warning_ignore_restore("unused_signal")
