import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Block {
  final int index;
  final DateTime timestamp;
  final String data;
  final String previousHash;
  late String hash;
  int nonce = 0;

  Block({
    required this.index,
    required this.timestamp,
    required this.data,
    required this.previousHash,
  }) {
    hash = calculateHash();
  }

  String calculateHash() {
    var bytes = utf8.encode('$index$timestamp$data$previousHash$nonce');
    return sha256.convert(bytes).toString();
  }

  void mineBlock(int difficulty) {
    String target = '0' * difficulty;
    while (hash.substring(0, difficulty) != target) {
      nonce++;
      hash = calculateHash();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'timestamp': timestamp,
      'data': data,
      'previousHash': previousHash,
      'hash': hash,
      'nonce': nonce,
    };
  }
}

class SimulatedBlockchain {
  final FirebaseFirestore _firestore;
  final int difficulty = 2;

  SimulatedBlockchain(this._firestore);

  Future<List<Block>> getChain() async {
    final snapshot =
        await _firestore.collection('blockchain').orderBy('index').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Block(
        index: data['index'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        data: data['data'],
        previousHash: data['previousHash'],
      )
        ..hash = data['hash']
        ..nonce = data['nonce'];
    }).toList();
  }

  Future<Block?> getLatestBlock() async {
    final chain = await getChain();
    if (chain.isEmpty) return null;
    return chain.last;
  }

  Future<void> addBlock(String data) async {
    final latestBlock = await getLatestBlock();
    final newIndex = latestBlock == null ? 0 : latestBlock.index + 1;
    final newBlock = Block(
      index: newIndex,
      timestamp: DateTime.now(),
      data: data,
      previousHash: latestBlock?.hash ?? '0',
    );

    newBlock.mineBlock(difficulty);

    await _firestore
        .collection('blockchain')
        .doc(newBlock.hash)
        .set(newBlock.toMap());
  }

  Future<bool> isChainValid() async {
    final chain = await getChain();

    for (int i = 1; i < chain.length; i++) {
      final currentBlock = chain[i];
      final previousBlock = chain[i - 1];

      if (currentBlock.hash != currentBlock.calculateHash()) {
        return false;
      }

      if (currentBlock.previousHash != previousBlock.hash) {
        return false;
      }
    }

    return true;
  }
}
