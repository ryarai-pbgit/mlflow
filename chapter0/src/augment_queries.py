#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
自然言語クエリのデータ拡張スクリプト
既存の3000件から5000件に拡張
"""

import random
import re

# 同義語辞書（拡充版）
SYNONYMS = {
    '教えてください': ['知りたい', '教えて', '見せてください', '見せて', '表示して', '出して'],
    '教えて': ['教えてください', '知りたい', '見せて', '表示して'],
    '知りたい': ['教えてください', '教えて', '確認したい', '把握したい', 'わかりたい'],
    '見せて': ['教えて', '表示して', '見せてください', '出して'],
    'ですか？': ['でしょうか？', 'か？', 'ですか', 'でしょうか', 'なのか？'],
    'ですか': ['でしょうか', 'か', 'なのか', 'なのでしょうか'],
    'はどうですか': ['はどうでしょうか', 'はどう', 'の状況は', 'はいかがですか', 'はどのようですか'],
    'を比較したい': ['の比較をしたい', 'を比べたい', 'の違いを知りたい', 'との比較は', 'と比べると'],
    'を分析したい': ['の分析をしたい', 'を調べたい', 'を見たい', 'の分析結果は', 'を解析したい'],
    'を調べたい': ['を分析したい', 'を確認したい', 'を見たい', 'を調査したい'],
    '顧客': ['ユーザー', 'ユーザ', '利用者', 'カスタマー', '会員'],
    'ユーザー': ['顧客', 'ユーザ', '利用者', '会員'],
    'ユーザ': ['顧客', 'ユーザー', '利用者', '会員'],
    '利用者': ['顧客', 'ユーザー', 'ユーザ'],
    '平均': ['平均値', '平均的な', 'アベレージ', '平均'],
    '平均値': ['平均', '平均的な値'],
    '合計': ['総計', '合計額', '総額', 'トータル', '計'],
    '総額': ['合計', '総計', 'トータル'],
    '割合': ['比率', 'パーセンテージ', 'シェア', '率', 'レート'],
    '比率': ['割合', 'レート', 'シェア'],
    '最も': ['一番', 'もっとも', '最高に', '最大に'],
    '一番': ['最も', 'もっとも', 'トップの', '第一の'],
    'トップ': ['上位', 'トップの', '最上位', '第一位'],
    '上位': ['トップ', '上位の', 'ランキング上位', '高順位'],
    '高い': ['高額な', '多い', '大きい', '高め'],
    '低い': ['低額な', '少ない', '小さい', '低め'],
    '多い': ['多数の', '高い', '多くの', '大量の'],
    '少ない': ['少数の', '低い', '少なめの', '少量の'],
    'は': ['について', 'に関して', 'の'],
    'について': ['は', 'に関して', 'に関する'],
    'に関して': ['について', 'は', 'の'],
    'ランキング': ['ランク', 'トップ', '順位', '順番'],
    '順位': ['ランキング', 'ランク', '順番'],
    '特徴': ['特性', '傾向', 'パターン', '特徴点', '性質'],
    '傾向': ['トレンド', '特徴', 'パターン', '動向', '推移'],
    'トレンド': ['傾向', '動向', 'パターン'],
    'パターン': ['傾向', '特徴', 'トレンド', '様式'],
    '購買': ['購入', '買い物', '消費', '購買活動'],
    '購入': ['購買', '買い物', '消費'],
    '買い物': ['購入', '購買', 'ショッピング'],
    '取引': ['トランザクション', '購買', '購入', '決済'],
    'トランザクション': ['取引', '購買', '購入'],
    '延滞': ['滞納', '遅延', '未払い', '延滞'],
    '滞納': ['延滞', '未払い', '遅延'],
    '年収': ['収入', '所得', '年間収入', '年間所得'],
    '収入': ['年収', '所得', '稼ぎ'],
    '所得': ['年収', '収入'],
    '年齢': ['年齢層', '世代', 'エイジ', '年代'],
    '年齢層': ['年齢', '世代', '年代'],
    '世代': ['年齢層', '年齢', '年代'],
    '地域': ['エリア', '地区', '場所', '地方'],
    'エリア': ['地域', '地区', 'ゾーン'],
    '地区': ['地域', 'エリア', '場所'],
    '分析': ['解析', '検討', '調査'],
    '解析': ['分析', '検討'],
    '確認': ['チェック', '検証', '把握'],
    'チェック': ['確認', '検証'],
    '推移': ['変化', 'トレンド', '遷移'],
    '変化': ['推移', '変動', '遷移'],
    '表示': ['出力', '表現', '可視化'],
    '可視化': ['表示', '図示', 'ビジュアル化'],
}

# 語尾バリエーション
ENDINGS = {
    'ですか？': ['でしょうか？', 'ですか', 'か？'],
    'ですか': ['でしょうか', 'か', 'なのか'],
    'したい': ['したいです', 'したいのですが', 'したい'],
    'はいますか？': ['はいるか？', 'はいるでしょうか？', 'はいますか'],
    'は？': ['はどうですか？', 'を教えて', 'は'],
}

def augment_query(query, seed=None):
    """クエリを拡張する"""
    if seed is not None:
        random.seed(seed)
    
    # 元のクエリをコピー
    augmented = query
    
    # ランダムに1-3個の変換を適用
    num_changes = random.randint(1, 3)
    changes_made = 0
    
    # 同義語置換を試行
    attempts = 0
    max_attempts = 20
    
    while changes_made < num_changes and attempts < max_attempts:
        attempts += 1
        
        # ランダムに同義語を選択
        if random.random() < 0.7 and changes_made < num_changes:
            for word, synonyms in SYNONYMS.items():
                if word in augmented and random.random() < 0.3:
                    replacement = random.choice(synonyms)
                    # 同じ単語への置換を避ける
                    if replacement != word:
                        augmented = augmented.replace(word, replacement, 1)
                        changes_made += 1
                        break
    
    # 少なくとも元のクエリと異なることを保証
    if augmented == query:
        # 強制的に1つ置換
        for word, synonyms in SYNONYMS.items():
            if word in augmented:
                replacement = random.choice(synonyms)
                if replacement != word:
                    augmented = augmented.replace(word, replacement, 1)
                    break
    
    return augmented

def main():
    # 元のファイルを読み込み
    input_file = '/Users/arairyousuke/Desktop/mywork/mlflow/natural_language_queries_10.txt'
    output_file = '/Users/arairyousuke/Desktop/mywork/mlflow/natural_language_queries_10.txt'
    
    with open(input_file, 'r', encoding='utf-8') as f:
        original_queries = [line.strip() for line in f if line.strip()]
    
    print(f"元のクエリ数: {len(original_queries)}")
    
    # 拡張が必要な数
    target_count = 10000
    current_count = len(original_queries)
    needed = target_count - current_count
    
    print(f"必要な追加数: {needed}")
    
    # 拡張クエリを生成
    augmented_queries = []
    
    # 各クエリから複数のバリエーションを生成
    for i in range(needed):
        # ランダムに元のクエリを選択
        source_query = random.choice(original_queries)
        # シードを変えて異なるバリエーションを生成
        aug_query = augment_query(source_query, seed=i)
        
        # 重複チェック
        attempts = 0
        while (aug_query in original_queries or aug_query in augmented_queries) and attempts < 10:
            source_query = random.choice(original_queries)
            aug_query = augment_query(source_query, seed=i * 100 + attempts)
            attempts += 1
        
        augmented_queries.append(aug_query)
        
        if (i + 1) % 100 == 0:
            print(f"進捗: {i + 1}/{needed} 生成完了")
    
    # 元のクエリと拡張クエリを結合
    all_queries = original_queries + augmented_queries
    
    print(f"最終クエリ数: {len(all_queries)}")
    
    # ファイルに書き出し
    with open(output_file, 'w', encoding='utf-8') as f:
        for query in all_queries:
            f.write(query + '\n')
    
    print(f"完了！{output_file} に {len(all_queries)} 件保存しました")
    
    # サンプル表示
    print("\n=== 拡張例 ===")
    for i in range(min(5, len(augmented_queries))):
        print(f"拡張 {i+1}: {augmented_queries[i]}")

if __name__ == '__main__':
    main()

