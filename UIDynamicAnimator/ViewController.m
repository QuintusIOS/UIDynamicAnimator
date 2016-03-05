//
//  ViewController.m
//  UIDynamicAnimator
//
//  Created by Toshiaki Nakamura on 2016/01/12.
//  Copyright © 2016年 Toshiaki Nakamura. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UICollisionBehaviorDelegate>{
    IBOutlet UIView *blueView;
    IBOutlet UIView *redView;
    
    UIDynamicAnimator *animator;
    UIDynamicItemBehavior *itemBehavior;
    UIGravityBehavior *gravityBehavior;
    UICollisionBehavior *collisionBehavior;
    UIPushBehavior *pushBehavior;
    UISnapBehavior *snapBehavior;
    UIAttachmentBehavior *attachmentBehavior;
    
    NSArray *items;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // アニメーターに追加するアイテムを保存するための配列を初期化する
    items = [NSArray array];
    
    // アイテムを作成する
    [self makePanda];
    
    // アニメーターを設定する
    [self makeAnimator];
    
    // ルートビューにタップジェスチャーを設定する
    [self makeTapViewGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeTapViewGesture{
    // ルートビューをタップしたときにエンジェルをスナップで移動する
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendSnap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)sendSnap:(UITapGestureRecognizer *)sender{
    // アタッチメントビヘイビアでエンジェルとデビルを接続する
    [animator removeBehavior:attachmentBehavior];
    attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:items[0] attachedToItem:items[1]];
    attachmentBehavior.damping = 0.1;
    UIImageView *angel = (UIImageView *)sender.view;
    attachmentBehavior.length = angel.bounds.size.width / 3.0;
    attachmentBehavior.frequency = 6;
    [animator addBehavior:attachmentBehavior];
    
    // 移動先（タップした座標）を取得する
    CGPoint pt = [sender locationInView:self.view];
    // 登録済みのスナップを削除してからつくりなおす
    [animator removeBehavior:snapBehavior];
    snapBehavior = [[UISnapBehavior alloc] initWithItem:items[0] snapToPoint:pt];
    
    [animator addBehavior:snapBehavior];
}

- (void)makePanda{
    // 天使のイメージビューをつくって画面に追加する
    UIImageView *angelImageView = [self makeImageViewWithName:@"angel"];
    CGFloat x = self.view.frame.size.width / 10 * 4;
    CGFloat y = 0;
    angelImageView.center = CGPointMake(x, y);
    [self.view addSubview:angelImageView];
    
    // 悪魔のイメージビューをつくって画面に追加する
    UIImageView *devilImageView = [self makeImageViewWithName:@"devil"];
    x = self.view.frame.size.width / 10 * 8;
    y = 0;
    devilImageView.center = CGPointMake(x, y);
    [self.view addSubview:devilImageView];
    
    // イメージビューを配列に登録する
    items = [NSArray arrayWithObjects:angelImageView, devilImageView, nil];
}

- (void)makeAnimator{
    // アイテムビヘイビアを設定する
    itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:items];
    itemBehavior.density = 0.7f;    //比重
    itemBehavior.elasticity = 0.7f; //弾性
    itemBehavior.friction = 0.5f;   //反発
    itemBehavior.resistance = 0.8f; //抵抗
    
    // 重力ビヘイビアを設定する
    gravityBehavior = [[UIGravityBehavior alloc] initWithItems:items];
    
    // 衝突ビヘイビアを設定する
    collisionBehavior = [[UICollisionBehavior alloc] initWithItems:items];
    // 画面からはみ出さないようにする
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    collisionBehavior.collisionDelegate = self;
    // 青いビューから壁を作る
    UIBezierPath *blueBesierPath = [UIBezierPath bezierPathWithRect:blueView.frame];
    [collisionBehavior addBoundaryWithIdentifier:(id<NSCopying>)@"blueView" forPath:blueBesierPath];
    // 赤いビューから壁を作る
    UIBezierPath *redBesierPath = [UIBezierPath bezierPathWithRect:redView.frame];
    [collisionBehavior addBoundaryWithIdentifier:(id<NSCopying>)@"redView" forPath:redBesierPath];
    
    // プッシュビヘイビアを設定する
    pushBehavior = [[UIPushBehavior alloc] initWithItems:items mode:UIPushBehaviorModeInstantaneous];
    
    // アニメーターを設定する
    animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    [animator addBehavior:itemBehavior];
    [animator addBehavior:gravityBehavior];
    [animator addBehavior:collisionBehavior];
    [animator addBehavior:pushBehavior];
}

- (UIImageView *)makeImageViewWithName:(NSString *)imageName{
    // イメージビューをつくって画面に追加する
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGFloat width = 80;
    CGFloat height = 80;
    imageView.bounds = CGRectMake(0, 0, width, height);
    
    // タップジェスチャーを作成する
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendPush:)];
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:tap];
    
    return imageView;
}

- (void)sendPush:(UITapGestureRecognizer *)sender{
    // タップされた場合はスナップとアタッチメントを削除する
    [animator removeBehavior:attachmentBehavior];
    [animator removeBehavior:snapBehavior];
    
    // タップされたイメージビューを取り出して変数imageViewに代入する
    UIImageView *imageView = (UIImageView *)sender.view;
    
    if (pushBehavior.items.count > 0) {
        // プッシュビヘイビアにアイテムが入っていたら取り除く
        [pushBehavior removeItem:items[0]];
        [pushBehavior removeItem:items[1]];
        // プッシュビヘイビアをアクティブにする
        pushBehavior.active = YES;
    }
    
    // タップしたイメージビューを45度〜135度のランダムな角度で上に飛ばす
    int randomAngle = arc4random_uniform(90) + 45;
    pushBehavior.angle = -randomAngle * (M_PI / 180);       //角度を設定（マイナスは上向き）
    pushBehavior.magnitude = 6.0f;                          //強さを設定
    [pushBehavior addItem:imageView];
    
}

// ふたつのアイテムが衝突したときに呼ばれるデリゲートメソッド
-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 atPoint:(CGPoint)p{
    // 引数のitem1とitem2をUIImageView型の変数に代入する
    UIImageView *item1ImageView = (UIImageView *)item1;
    UIImageView *item2ImageView = (UIImageView *)item2;
    
    // 背景色を変える
    item1ImageView.backgroundColor = [UIColor greenColor];
    [UIView animateWithDuration:0.7 animations:^{
        item1ImageView.backgroundColor = [UIColor whiteColor];
    }];
    
    item2ImageView.backgroundColor = [UIColor orangeColor];
    [UIView animateWithDuration:0.7 animations:^{
        item2ImageView.backgroundColor = [UIColor whiteColor];
    }];
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p{
    // 青いビューに衝突したとき
    if ([(NSString *)identifier isEqualToString:@"blueView"]) {
        // 青いビューの背景色を変える
        blueView.backgroundColor = [UIColor cyanColor];
        [UIView animateWithDuration:0.5 animations:^{
            blueView.backgroundColor = [UIColor blueColor];
        }];
    }
    // 赤いビューに衝突したとき
    if ([(NSString *)identifier isEqualToString:@"redView"]) {
        // 赤いビューの背景色を変える
        redView.backgroundColor = [UIColor yellowColor];
        [UIView animateWithDuration:0.5 animations:^{
            redView.backgroundColor = [UIColor redColor];
        }];
    }
}

@end
