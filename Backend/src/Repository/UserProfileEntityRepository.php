<?php

namespace App\Repository;

use App\Entity\UserProfileEntity;
use Doctrine\Bundle\DoctrineBundle\Repository\ServiceEntityRepository;
use Doctrine\Persistence\ManagerRegistry;

/**
 * @method UserProfileEntity|null find($id, $lockMode = null, $lockVersion = null)
 * @method UserProfileEntity|null findOneBy(array $criteria, array $orderBy = null)
 * @method UserProfileEntity[]    findAll()
 * @method UserProfileEntity[]    findBy(array $criteria, array $orderBy = null, $limit = null, $offset = null)
 */
class UserProfileEntityRepository extends ServiceEntityRepository
{
    public function __construct(ManagerRegistry $registry)
    {
        parent::__construct($registry, UserProfileEntity::class);
    }

    public function getProfileByUSerID($userID)
    {
        $r =  $this->createQueryBuilder('profile')

            ->andWhere('profile.userID=:userID')
            ->setParameter('userID', $userID)

            ->groupBy('profile.userID')
            ->getQuery()
            ->getOneOrNullResult();

        return $r;
    }
}
