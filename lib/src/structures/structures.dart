//
//  rope
//  structures.dart
//
//  Created by Ngonidzashe Mangudya on 2025/05/12.
//  Copyright (c) 2025 Codecraft Solutions. All rights reserved.
//

/// This file exports all the core data structures needed for the rope implementation.
///
/// The rope data structure is a tree-based data structure that provides efficient
/// text editing operations, especially for large documents. It breaks text into
/// smaller chunks and organizes them in a balanced tree to enable:
///
/// - O(log n) insertions and deletions at any position
/// - O(log n) access to any character
/// - O(log n) substring operations
///
/// The key components exported are:
///
/// - [Chunk]: The basic unit of text storage
/// - [SumTreeNode]: The base class for all nodes in the tree
/// - [LeafNode]: Terminal nodes that contain actual text chunks
/// - [InternalNode]: Non-terminal nodes that organize the tree structure
/// - [Summary]: Interface for metadata aggregation
/// - [TextSummary]: Specific implementation of summary for text operations

export 'chunk.dart';
export 'internal_node.dart';
export 'leaf_node.dart';
export 'sum_tree_node.dart';
export 'summary.dart';
export 'text_summary.dart';
